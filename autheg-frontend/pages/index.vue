<template>
  <v-layout>
    <v-flex>
      <v-list>
        <v-list-tile v-for="example in examples" :key="example.id" :class="example.colour">
          <v-list-tile-content>{{example.name}}</v-list-tile-content>
        </v-list-tile>
      </v-list>
    </v-flex>
  </v-layout>
</template>

<script>
export default {
  middleware: ['auth'],
  data () {
    return {
      examples: []
    }
  },
  methods: {
    async updateExamples() {
      this.examples = await this.$axios.$get('/examples')
    }
  },
  mounted () {
    this.updateExamples()
  }
}
</script>
